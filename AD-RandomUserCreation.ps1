

[int]$usercount = "10"                                                   ## Defines how many users will be created.
[int]$usercountstart = $usercount                                        ## Defines the fixed total

## Lists
#### Change these as required
$fnamelist = Get-Content 'C:\Users\Administrator\Documents\firstnames.txt' ## First Names list
$lnamelist = Get-Content 'C:\Users\Administrator\Documents\surnames.txt' ## Surnames list
$ranklist = Get-Content 'C:\Users\Administrator\Documents\ranks.txt'     ## Ranks list
$ou = @("OU=Helpdesk,OU=IT,OU=Accounts,DC=domain,DC=com","OU=Finance,OU=Accounts,DC=domain,DC=com","OU=Sales,OU=Accounts,DC=domain,DC=com","OU=HR,OU=Accounts,DC=domain,DC=com")
$password = "Pa55w0rd=01"                                                ## Set a default password
#### Do not edit beyond this line


#Import required module ActiveDirectory
try
{
  Import-Module ActiveDirectory -ErrorAction Stop
}
  catch
{
  throw "Module ActiveDirectory not Installed"
}

  While ($usercount -gt 0)
{

  $ou = (Get-Random -InputObject $ou)                                      ## Select a random OU from the list

  $firstname = Get-Random -InputObject $fnamelist                          ## Select a random First Name from the list
  $firstname = $firstname -replace '\s',''                                 ## Strip any spaces if present
  $firstname1 = $firstname.Substring(0,1)                                  ## Defines a variable for the first initial, used in the username

  $surname = Get-Random -InputObject $lnamelist                            ## Select a random Surname from the list
  $surname = $surname -replace '\s',''                                     ## Strip any spaces if present

  $rank = Get-Random -InputObject $ranklist                                ## Select a random rank from the list
  $rank = $rank -replace '\s',''                                           ## Strip any spaces if present

  $number = (Get-Random -Minimum 100 -Maximum 999)                         ## Define the range of numbers appending usernames

  $username = ($surname+$firstname1+$number).ToLower()                     ## Defines the username by concatanating the surname, first initial and random 3 digits

  $displayname = "$surname, $firstname $rank"                              ## Defines the Display Name by combining the Surname, Firstname and Rank

  $upn = "$firstname.$surname$number" +"@"+ (Get-AdDomain).DNSroot         ## Defines the Display Name by concatanating the <firstname>[.]<surname><random digits> and the domain name

      $exit = 0
      
      do
      {
          try
          {
              $userexists = Get-ADUser -identity $username                 ## Does the user exist already?
              $number = (Get-Random -Minimum 100 -Maximum 999)             ## If so, generate a new number
              $username = $surname+$firstname1+$number                     ## Defines the username with the new number
              $upn = "$firstname.$surname$number" +"@"+ (Get-AdDomain).DNSroot ## Defines the upn with the new number
          }
          catch
          {
              $exit = 1
          }
      }
      while ($exit -eq 0)



      Write-Host "Creating user $username in $ou"                          ## Prints to console which user was created and in what OU they were placed
      New-ADUser -Name $displayname -Displayname $displayname `            ## Creates the new user with the previous details
      -SamAccountName $username -UserPrincipalName $upn `
      -GivenName $firstname -Surname $surname `
      -Path $ou -Enabled $true -ChangePasswordAtLogon $false `
      -AccountPassword (ConvertTo-SecureString $Password -AsPlainText -force)


      $usercount--                                                         ## Deducts 1 from the user counter 
      if ($usercount -eq 0) {                                              ## When the user counter reaches zero, print to console the task being complete and how many users were created.
      Write-Host "User creation complete, $usercountstart total created."
      }
}
