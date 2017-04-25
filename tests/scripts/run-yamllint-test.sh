echo "TESTING TESTS!!!!!!"
for file in $(find tests -iname '*.yaml')
do
  # echo $file
  yamllint -c tests/yamllint.conf $file
done

echo "TESTING LIB!!!!!!"
for file in $(find lib -iname '*.yaml')
do
  # echo $file
  yamllint -c tests/yamllint.conf $file
done
