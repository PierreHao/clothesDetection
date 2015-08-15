cur_path=`pwd`
for file in `ls`
do
    out=`expr substr $file 10 100`
    mv $file $out
    echo 'test'
done
