#! /bin/bash
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)

printf "[ProType] [Dim] [Delta] [Size] [Com.(MB)] [Time(s)]\n"

for n in "${ns[@]}"; do
  for dim in "${dims[@]}"; do
    for delta in "${deltas[@]}"; do
      ../build/fpsi -d $dim -delta $delta -nn $n -fm -prefix -try 3
    done
    echo
  done
done


