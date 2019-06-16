# Init
# TIME_DIFF_LATEST_FILE=$(($(date +%s)-$(find hashicorp/solodev-php-72/windows-2016 -printf "%Ts\n" | sort | tail -1)))
# if [ "$FORCE_BUILDS" = true ] || [ $TIME_DIFF_LATEST_FILE -lt 3600 ] ; then
    echo "Validating - $2"
    ./packer validate $1/$2
    echo "Building - $2"
    ./packer build $1/$2
# else

# fi