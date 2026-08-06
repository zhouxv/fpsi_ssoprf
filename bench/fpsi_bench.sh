#! /bin/bash

#  We set Nr = Ns = 28,12,16,d = 6,10,15, and δ = 10,60,250.
metrics=(0 1 2)
ns=(8 12 16)
dims=(2 6 10 15)
deltas=(10 60 250)

printf "[ProType] [Metric] [Dim] [Delta] [Size] [Com.(MB)] [Time(s)]\n"

for m in "${metrics[@]}"; do
  for n in "${ns[@]}"; do
    for dim in "${dims[@]}"; do
      for delta in "${deltas[@]}"; do
        ../build/fpsi -d $dim -delta $delta -nn $n -p $m -try 3
      done
      echo 
    done
  done
done


