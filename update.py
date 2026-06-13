import json
import urllib.request

# Put your GitHub username here
USERNAME = "akashaimor"

def get_my_repos():
    
    api_url = f"https://api.github.com/users/{USERNAME}/repos?sort=updated"
    
    request = urllib.request.Request(api_url, headers={'User-Agent': 'Mozilla/5.0'})
    try:
        print("Connecting to GitHub...")
        with urllib.request.urlopen(request) as response:
            all_repos = json.loads(response.read().decode())
            
        my_projects = []
        
        for repo in all_repos:
            
            if repo['fork']:
                continue
                
            
            lang = repo.get('language') or 'Design'
            
            if lang in ['HTML', 'CSS', 'JavaScript', 'TypeScript']:
                category = "Web"
            else:
                category = "Code"
                
            
            clean_title = repo['name'].replace('-', ' ').title()
            
            
            description = repo['description'] or "A project built and managed on my GitHub."
            
           
            project_item = {
                "title": clean_title,
                "description": description,
                "category": category,
                "tech": lang,
                "link": repo['html_url']
            }
            
            my_projects.append(project_item)
            
        
        with open("projects.json", "w") as file:
            json.dump(my_projects, file, indent=4)
            
        print(f"Done! Successfully loaded {len(my_projects)} projects.")


    
    except Exception as error:
        print("Something went wrong:", error)

if __name__ == "__main__":
    get_my_repos()
