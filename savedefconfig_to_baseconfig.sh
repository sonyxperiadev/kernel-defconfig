if [ -z "$1" ] || [ -z "$2" ]
    then
        echo "Usage: ./savedefconfig_to_baseconfig.sh defconfig output_name"
	exit 1
fi

echo "Processing file: $1"
echo "Output file: $2"

if [ -f "$1" ]; then
    cat android-base.config \
        android-recommended.config \
        android-recommended-arm64.config > \
        /tmp/android_recommended && \
    sort -o /tmp/android_recommended /tmp/android_recommended && \
    comm -1 -3 /tmp/android_recommended <(sort $1) > $2 && \
    rm /tmp/android_recommended && \
    echo "$2 is ready!"
else
    echo "File '$1' does not exist."
fi
