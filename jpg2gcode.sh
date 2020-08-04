## install 
# apt install -y ffmpeg


INPUT_VIDEO=/dev/video0
OUTPUT_VIDEO=/tmp/output.mkv
IMG_IN=/tmp/in
IMG_OUT=/tmp/out
IMG_REJECT=/tmp/reject
CAPTURE_MOSAIC=/tmp/out/mosaic.jpg

# TOTO: argv
if [ "xxx$2" == "xxx" ]; then
  echo "Missing arg:  [1|2|3|4] pseudo"
  exit 1
fi
re='^[0-9]+$'
if ! [[ $1 =~ $re ]] ; then
  echo "Missing arg:  [1|2|3|4]"
  exit 2
fi
NUM=$1
PSEUDO=$2

# getting file name
IMAGE=$(ls ${IMG_OUT}/output*.jpg |tail -n 4|sed "${NUM}q;d")
IMAGE="${IMG_OUT}/$(basename $IMAGE .jpg)"

if [ ! -f "${IMAGE}.jpg" ]; then
  echo "$IMAGE does not exist."
  exit 3
fi

#/usr/local/bin/cartoon -p 30 -n 40 -e 6 ${IMAGE}.jpg ${IMAGE}.png

#convert ${IMAGE}.png -flatten  -colorspace Gray -negate -edge 2 -negate -threshold 50% ${IMAGE}.ppm
#potrace -s ${IMAGE}.ppm -b svg --unit 100 --turdsize 5 --turnpolicy black -o ${IMAGE}.svg

/usr/local/bin/cartoon -p 30 -n 40 -e 6 -m 1 ${IMAGE}.jpg ${IMAGE}.png

convert ${IMAGE}.png -flatten -colorspace Gray -negate -edge 2 -negate -threshold 50% ${IMAGE}.ppm

# on insert le pseudo
convert -pointsize 70 -font "From-Street-Art" label:${PSEUDO} -threshold 50% -trim +repage -bordercolor white -border 5x5 ${IMG_OUT}/text.ppm
convert ${IMAGE}.ppm -gravity center ${IMG_OUT}/text.ppm -append ${IMAGE}_text.ppm

convert -rotate -90 ${IMAGE}_text.ppm ${IMAGE}_text_rotated.ppm

potrace -s ${IMAGE}_text_rotated.ppm -b svg --unit 100 --turdsize 5 --turnpolicy black -o ${IMAGE}.svg
/usr/local/bin/svg2gcode -B -F ${IMAGE}.svg ${IMAGE}.gcode
