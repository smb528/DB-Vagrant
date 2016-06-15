

    #Change hostname to dbdev
    old=$(hostname)
    new="dbdev"
    for file in \
       /etc/exim4/update-exim4.conf.conf \
       /etc/printcap \
       /etc/hostname \
       /etc/hosts \
       /etc/ssh/ssh_host_rsa_key.pub \
       /etc/ssh/ssh_host_dsa_key.pub \
       /etc/motd \
       /etc/ssmtp/ssmtp.conf
    do
       sudo [ -f $file ] && sudo sed -i.old -e "s:$old:$new:g" $file
    done
    sudo hostname dbdev
    
    
    #Update Aptitude
    sudo apt-get update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
    sudo apt-get install -y gcc build-essential module-assistant
    
    #Install Emacs and gedit and vim 
    sudo apt-get install -y emacs gedit vim less
    
    #Install htop
    sudo apt-get install htop -y
    
    #Install git 
    sudo apt-get install git -y
    
    #Install linux headers for good measure
    sudo apt-get install -y dkms linux-headers-$(uname -r)
    
    #Install perl-docs
    sudo apt-get install perl-doc -y 
    
    #Install memtester
    sudo apt-get install memtester -y
    
    #Install ack-grep
    sudo apt-get install ack-grep -y
    
    #Set root user password to vagrant 
    yes vagrant | sudo passwd root
    
    #Set Superuser: vagrant user already NOPASSWD superuser

    #Install curl
    sudo apt-get install curl -y
    
    #Install cpanmin
    curl -L https://cpanmin.us | perl - --sudo App::cpanminus
    
    #Install Iceweasel
    sudo apt-get install iceweasel -y
    
    #Install libreoffice
    sudo apt-get install libreoffice -y
    
    #Install Nginx
    sudo apt-get install nginx -y
    
    #NMAP
    sudo apt-get install -y nmap

    #install gnome
    sudo apt-get install gnome-core -y
    sudo apt-get install gnome-terminal -y
    sudo apt-get install -y gnome-shell gnome-screensaver gnome-tweak-tool gnome-shell-extensions

    #Permit any user to start the GUI
    sudo sed -i s/allowed_users=console/allowed_users=anybody/ /etc/X11/Xwrapper.config

    #Enable automatic gnome login for vagrant user
    sudo sed -i s/\#\ \ AutomaticLoginEnable\ =\ true/AutomaticLoginEnable\ =\ true/ /etc/gdm3/daemon.conf
    sudo sed -i s/\#\ \ AutomaticLogin\ =\ user1/AutomaticLogin\ =\ vagrant/ /etc/gdm3/daemon.conf
    #Start GNOME GUI
    sudo /etc/init.d/gdm3 start

  
    #Install postgres 9.5
    sudo su -c "echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main 9.5' > /etc/apt/sources.list.d/postgresql.list"
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update -y 
    sudo apt-get install postgresql-9.5 -y
    
    #Configure trust connection for psql postgres user and create web_usr .
    sudo sed -i s/peer/trust/ /etc/postgresql/9.5/main/pg_hba.conf 
    sudo /etc/init.d/postgresql restart
    #Create web_usr role with password web_usr
    yes web_usr | createuser -U postgres -P web_usr
    #Change postgres role password to postgres
    echo "ALTER ROLE postgres WITH PASSWORD 'postgres';" | psql -U postgres 
    sudo /etc/init.d/postgresql restart

    #load fixture
    mkdir cxgn
    cd cxgn
    git clone https://github.com/solgenomics/fixture.git
    sudo -u postgres createdb -E UTF8 --locale en_US.utf8 -T template0 fixture
    sudo psql -U postgres -d fixture -f /home/vagrant/cxgn/fixture/cxgn_fixture.sql
    echo "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO web_usr;" | psql -U postgres -d fixture
    echo "GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO web_usr;" | psql -U postgres -d fixture

    #install monetdb

    #make monetdb.list file
    cd /etc/apt/sources.list.d
    sudo gedit /etc/apt/sources.list.d/monetdb.list
    
    #insert these commands into the file
    #deb http://dev.monetdb.org/downloads/deb/ jessie monetdb
    #deb-src http://dev.monetdb.org/downloads/deb/ jessie monetdb

    #check which version of debian
    sudo apt-get install lsb-release
    #lsb_release -da
    
    #install public key
    wget --output-document=- https://www.monetdb.org/downloads/MonetDB-GPG-KEY | sudo apt-key add

    #update
    sudo apt-get update

    sudo apt-get install monetdb5-sql monetdb-client
    
    #add users
    sudo usermod -a -G monetdb $USER



    #Install MongoDB
    
    #public key install
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927

    #create list file
    echo "deb http://repo.mongodb.org/apt/debian wheezy/mongodb-org/3.2 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
    #update
    sudo apt-get update
    #installing packages
    sudo apt-get install -y mongodb-org

    #Install DBI
    sudo cpanm install Bundle::DBI
