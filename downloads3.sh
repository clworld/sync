#!/bin/sh
BASEDIR=`dirname $0`
BUCKET=$1
if [ "x" = "x${BUCKET}" ]; then
  echo "usage: $0 s3-bucket-name"
  exit 1
fi
cd $BASEDIR
BASEFULLDIR=`pwd`
SYNCDIR=`basename "${BASEFULLDIR}"`
cd ..
aws s3 sync s3://${BUCKET}/${SYNCDIR} ${SYNCDIR}
chmod a+x sync/*.sh sync/*.rb
${SYNCDIR}/loadlinks.rb ${SYNCDIR}/symlinks.txt
RESULT=$?
if [ "x0" != "x${RESULT}" ]; then
  echo "loadlinks.rb failed."
  exit 1
fi
aws s3 sync s3://${BUCKET} . --exclude "public/system/*" --exclude "data/*" --exclude "log/*" --exclude "tmp/*" --include "*/.gitkeep" --exclude "vendor/bundle/*" --exclude "node_modules/*" --no-follow-symlinks --exact-timestamps --delete
RESULT=$?
if [ "x0" != "x${RESULT}" -a "x2" != "x${RESULT}" ]; then
  echo "sync failed."
  exit 1
fi
chmod a+x `cat ${SYNCDIR}/exec.txt`
