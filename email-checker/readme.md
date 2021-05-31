# Email-checker.sh

Email-checker.sh is a script for troubleshooting common email problems for self hosted email servers, currently the script can check the following,

- The mail servers IP against server blacklists
- The domain has a valid SPF record
- Common mail ports are open
- for valid FCrDNS

## Using the script.

Most checks can be called on individually to perform certain checks, useful if you want to check if a change has corrected an issue.

### Downloading the script

```bash
wget https://raw.githubusercontent.com/DPR1604/Linux-scripts/master/email-checker/email-checker.sh
chmod 755 email-checker.sh
```

### Declaring an IP or domain name

Declaring an IP is done with the `-i` flag;

```bash
email-checker.sh -i 1.1.1.1
```

Declaring a Domain name is doen with the `-d` flag;

```bash
email-checker.sh -d example.com
```

### Perform all checks

This can be done with the `-a` flag;

```bash
email-checker.sh -d example.com -a
```

### Blacklist check

Blacklist checks can be called with the `-b` flag 

```bash
email-checker.sh -d example.com -b
```
or
```bash
email-checker.sh -i 1.1.1.1 -b
```

### SPF check

SPF check can be called with '-s'
```bash
email-checker.sh -d example.com -s
```
### FCrDNS check 

FCrDNS checks can be called with `-f`

```bash
email-checker.sh -d example.com -f
```

### Port check

Port checks can be called with `-p`
```bash
email-checker.sh -d example.com -p
```
or
```bash
email-checker.sh -i 1.1.1.1 -p 
```
