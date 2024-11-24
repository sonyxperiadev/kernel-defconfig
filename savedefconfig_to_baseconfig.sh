if [ -z "$1" ] || [ -z "$2" ]
    then
        echo "Usage: ./savedefconfig_to_baseconfig.sh defconfig output_name"
	exit 1
fi

echo "Processing file: $1"
echo "Output file: $2"

if [ -f "$1" ]; then
    grep -vf android-base.config $1 > $2 && \
    grep -vf gki_defconfig $1 > $2 && \
    echo "$2 is ready!"
else
    echo "File '$1' does not exist."
fi
