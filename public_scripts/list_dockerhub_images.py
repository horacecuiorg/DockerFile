import requests
import os
import json # 导入 json 模块

def get_docker_hub_auth_token(username, password):
    """尝试获取 Docker Hub 认证 token。"""
    # 认证范围可以针对任何公共仓库，例如 library/ubuntu
    auth_url = "https://auth.docker.io/token?service=registry.docker.io&scope=repository:library/ubuntu:pull"
    try:
        response = requests.get(auth_url, auth=(username, password))
        response.raise_for_status() # 如果请求失败，抛出 HTTPError
        return response.json().get("token")
    except requests.exceptions.RequestException as e:
        print(f"Error getting Docker Hub auth token: {e}")
        return None

def fetch_paginated_data(url, headers=None):
    """
    通用函数，用于从支持分页的 API 获取所有数据。
    """
    all_results = []
    next_page = url
    while next_page:
        try:
            response = requests.get(next_page, headers=headers)
            response.raise_for_status()
            data = response.json()
            all_results.extend(data.get("results", []))
            next_page = data.get("next")
        except requests.exceptions.RequestException as e:
            print(f"Error fetching data from {next_page}: {e}")
            break
    return all_results

def main():
    namespace = os.environ.get("TARGET_NAMESPACE")
    use_auth_str = os.environ.get("USE_DOCKER_HUB_AUTH", "false").lower()
    use_auth = use_auth_str == "true"

    username = os.environ.get("DOCKER_HUB_USERNAME")
    password = os.environ.get("DOCKER_HUB_PASSWORD") # 从环境变量获取密码

    headers = {}
    if use_auth:
        if not username or not password:
            print("Warning: USE_DOCKER_HUB_AUTH is true, but DOCKER_HUB_USERNAME or DOCKER_HUB_PASSWORD is not set.")
            print("Proceeding without authentication. This may lead to rate limits or failure for private repos.")
        else:
            auth_token = get_docker_hub_auth_token(username, password)
            if auth_token:
                headers["Authorization"] = f"Bearer {auth_token}"
                print("Authenticated successfully to Docker Hub.")
            else:
                print("Failed to authenticate to Docker Hub. Proceeding without authentication.")


    print(f"Listing Docker Hub images for namespace: {namespace}")
    print(f"Authentication used: {use_auth}")

    # --- Fetch Repositories (Images) ---
    repos_url = f"https://hub.docker.com/v2/namespaces/{namespace}/repositories?page_size=100"
    repositories = fetch_paginated_data(repos_url, headers=headers)

    if not repositories:
        print(f"No repositories found for namespace {namespace}.")
        return

    print(f"Found {len(repositories)} repositories.")
    print("-" * 50)

    # --- Process Each Image and its Tags ---
    for repo in repositories:
        image_name = repo.get("name")
        if not image_name:
            continue

        print(f"Image: {namespace}/{image_name}")
        print("-----------------------------------")

        tags_url = f"https://hub.docker.com/v2/repositories/{namespace}/{image_name}/tags?page_size=100"
        tags = fetch_paginated_data(tags_url, headers=headers)

        if not tags:
            print("  No tags found for this image.")
            print("")
            continue

        for tag_info in tags:
            tag_name = tag_info.get("name")
            last_updated = tag_info.get("last_updated")
            full_size_bytes = tag_info.get("full_size", 0)
            full_size_mb = f"{(full_size_bytes / (1024 * 1024)):.2f} MB" if full_size_bytes else "N/A"

            digest = "N/A"
            architectures = []
            if tag_info.get("images"):
                # Collect all unique architectures and OS
                for img in tag_info["images"]:
                    if img.get("digest"):
                        digest = img["digest"] # This will be the last digest if multiple are present, fine for display
                    arch = img.get("architecture")
                    os_name = img.get("os")
                    if arch and os_name:
                        architectures.append(f"{arch}/{os_name}")
            
            arch_str = ", ".join(sorted(list(set(architectures)))) if architectures else "N/A"

            print(f"  Tag:         {tag_name}")
            print(f"  ID (digest): {digest}")
            print(f"  Pushed At:   {last_updated}")
            print(f"  Size:        {full_size_mb}")
            print(f"  Architectures: {arch_str}")
            print("-----------------------------------")
        print("") # Blank line after each image

if __name__ == "__main__":
    main()