# InSeeTC

###### _Installation_

`composer install`



```
Use <owner/repo> param to get latest commit sha
 
 Usage:  [OPTIONS...] [ARGUMENTS...]
 
 Arguments:
   <arg>       Repository name in owner/repo format
   [branch]    Branch name, master by default
 
 Options:
   [-h|--help]         Show help
   [-u|--user]         The user
   [-p|--password]     The password
   [-t|--token]        The Personal access Token
   [-s|--service]      The service (git/bitbucket)
   [-v|--verbosity]    Verbosity level
   [-V|--version]      Show version
  
 
 Usage Examples:
  ./app --service git --token api_token --user user_name --password user_password <owner/repo> [master]  # details 1
  ./app -s git -t api_token -u user -p password <owner/repo> [master]                                    # details 2

```

###### Try

./app googleapis/google-api-php-client