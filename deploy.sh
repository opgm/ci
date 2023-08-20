#ssh comma 'rm -rf /data/openpilot_dev'
#rsync -zarv \
#  --delete \
#  --exclude='.mypy_cache' \
#  --exclude='.git' \
#  --exclude='.idea' \
#  --exclude='*.pyc' \
#  . comma:/data/openpilot_dev
rsync -zarv \
  --exclude='.mypy_cache' \
  --exclude='.git' \
  --exclude='.idea' \
  --exclude='*.pyc' \
  --exclude='*.o' \
  --exclude='*.so' \
  --exclude='*.a' \
  --exclude='*.os' \
  --exclude='rlogs/*' \
  . comma:/data/openpilot_dev
ssh comma 'rm -rf /data/openpilot && ln -s /data/openpilot_dev /data/openpilot'
