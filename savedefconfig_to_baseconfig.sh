if [ -z "$1" ] || [ -z "$2" ]
    then
        echo "Usage: ./savedefconfig_to_baseconfig.sh defconfig output_name"
	exit 1
fi

echo "Processing file: $1"
echo "Output file: $2"

if [ -f "$1" ]; then
    comm -1 -3 <(sort android-base.config) <(sort $1) > $2 && \
    comm -1 -3 <(sort android-recommended.config) <(sort $1) > $2 && \
    comm -1 -3 <(sort android-recommended-arm64.config) <(sort $1) > $2 && \
    comm -1 -3 <(sort android-extra.config) <(sort $1) > $2 && \
    echo "$2 is ready!"
else
    echo "File '$1' does not exist."
fi
