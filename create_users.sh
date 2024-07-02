#!/bin/bash

# Check if the script is run with an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Input file
input_file=$1

# Log file and password file (using project directory)
log_file="./user_management.log"
password_file="./user_passwords.csv"

# Ensure secure directory for passwords exists
mkdir -p ./secure
chmod 700 ./secure

# Clear previous log and password files
echo "" > $log_file
echo "" > $password_file
chmod 600 $password_file

# Function to generate random passwords
generate_password() {
    local password=$(openssl rand -base64 12)
    echo $password
}

# Read the input file line by line
while IFS=';' read -r username groups; do
    # Remove whitespaces
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)

    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists" | tee -a $log_file
        continue
    fi

    # Create the user and personal group
    useradd -m -s /bin/bash $username
    echo "Created user $username with home directory" | tee -a $log_file

    # Set user's password
    password=$(generate_password)
    echo "$username:$password" | chpasswd
    echo "Set password for user $username" | tee -a $log_file

    # Save the username and password to the password file
    echo "$username,$password" >> $password_file

    # Create additional groups and add the user to them
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs) # Remove whitespaces
        if ! getent group "$group" >/dev/null; then
            groupadd $group
            echo "Created group $group" | tee -a $log_file
        fi
        usermod -aG $group $username
        echo "Added user $username to group $group" | tee -a $log_file
    done

    echo "Successfully processed user $username" | tee -a $log_file
done < "$input_file"

echo "User creation script completed" | tee -a $log_file
#!/bin/bash

# Check if the script is run with an argument
if [ $# -eq 0 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

# Input file
input_file=$1

# Log file and password file (using project directory)
log_file="./user_management.log"
password_file="./user_passwords.csv"

# Ensure secure directory for passwords exists
mkdir -p ./secure
chmod 700 ./secure

# Clear previous log and password files
echo "" > $log_file
echo "" > $password_file
chmod 600 $password_file

# Function to generate random passwords
generate_password() {
    local password=$(openssl rand -base64 12)
    echo $password
}

# Read the input file line by line
while IFS=';' read -r username groups; do
    # Remove whitespaces
    username=$(echo $username | xargs)
    groups=$(echo $groups | xargs)

    # Check if user already exists
    if id "$username" &>/dev/null; then
        echo "User $username already exists" | tee -a $log_file
        continue
    fi

    # Create the user and personal group
    useradd -m -s /bin/bash $username
    echo "Created user $username with home directory" | tee -a $log_file

    # Set user's password
    password=$(generate_password)
    echo "$username:$password" | chpasswd
    echo "Set password for user $username" | tee -a $log_file

    # Save the username and password to the password file
    echo "$username,$password" >> $password_file

    # Create additional groups and add the user to them
    IFS=',' read -ra ADDR <<< "$groups"
    for group in "${ADDR[@]}"; do
        group=$(echo $group | xargs) # Remove whitespaces
        if ! getent group "$group" >/dev/null; then
            groupadd $group
            echo "Created group $group" | tee -a $log_file
        fi
        usermod -aG $group $username
        echo "Added user $username to group $group" | tee -a $log_file
    done

    echo "Successfully processed user $username" | tee -a $log_file
done < "$input_file"

echo "User creation script completed" | tee -a $log_file
