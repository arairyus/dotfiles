{ username, homedir, ... }:

{
  users.users.${username} = {
    home = homedir;
  };
}
