#!/bin/bash

echo "--------------------------"
echo "User: 김민지"
echo "Student Number: 12212425"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"echo "2. Get the data of action genre movies from 'u.item’"
echo "3. Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data"
echo "4. Delete the ‘IMDb URL’ from ‘u.item"
echo "5. Get the data about users from 'u.user’"
echo "6. Modify the format of 'release date' in 'u.item’"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "--------------------------"
while true
do
	echo -n "Enter your choice [ 1-9 ] "
	read choice

	case $choice in
		1)
			echo -n "Please enter 'movie id' (1~1682): "
			read movieId

			info=$(cat u.item | awk -F"|" -v movieId="$movieId" '$1==movieId')
			echo $info
			;;

		2)
			echo -n "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n) : "
			read respond

			if [ "$respond" == "y" ]
			then
				awk -F"|" '$7=="1" {print $1, $2}' u.item | sort -n | head -10
			fi
			;;

		3)
			echo -n "Please enter the 'movie id' (1~1682): "
			read movieId

			awk -F" " -v movieId="$movieId" '
			$2==movieId {
				total += $3
				count++
			}
			END {
				printf "average rating of %s: %.5f\n", movieId, total/count
			}' u.data
			;;

		4)
			echo -n "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n): "
			read respond

			if [ "$respond" == "y" ]
			then
				sed 's/|http[^|]*|/||/g' u.item | sort -n | head -n 10
			fi
			;;

		5)
			echo -n "Do you want to get the data about users from 'u.user'?(y/n): "
			read respond

			if [ "$respond" == "y" ]
			then
				sed -e 's/|M|/|male|/' -e 's/|F|/|female|/' u.user | awk -F'|' '{ print "user " $1 " is " $2 " years old " $3 " " $4 }' | head -n 10
			fi
			;;

		6)
			echo -n "Do you want to Modify the format of 'release data' in 'u.item'?(y/n): "
			read respond

			if [ "$respond" == "y" ]
			then
				awk -F'|' '{ split($3,a,"-"); print $1 "|" $2 "|" a[3] "-" a[2] "-" a[1] "|" $4 "|" $5 "|" $6 "|" $7 "|" $8 "|" $9 "|" $10 "|" $11 "|" $12 "|" $13 "|" $14 "|" $15 "|" $16 "|" $17 "|" $18 "|" $19 "|" $20 "|" $21 "|" $22 "|" $23 "|" $24}' u.item | sed -e 's/-Jan-/01/g' -e 's/-Feb-/02/g' -e 's/-Mar-/03/g' -e 's/-Apr-/04/g' -e 's/-May-/05/g' -e 's/-Jun-/06/g' -e 's/-Jul-/07/g' -e 's/-Aug-/08/g' -e 's/-Sep-/09/g' -e 's/-Oct-/10/g' -e 's/-Nov-/11/g' -e 's/-Dec-/12/g' | awk -F'|' '$1 >=1673 && $1 <= 1682'
			fi
			;;

		7)
			echo -n "Please enter the 'user id' (1~943): "
			read userId

			awk -v id="$userId" -F' ' '{ if ($1 == id) print $2 }' u.data | sort -n | tr '\n' '|' | sed 's/|$//'
			echo
			echo

			movieIds=$(awk -v id="$userId" -F' ' '{ if ($1 == id) print $2 }' u.data)

			for movieId in $movieIds
			do
				awk -v movieId="$movieId" -F'|' '{ if ($1 == movieId) print $1 "|" $2 }' u.item
			done | sort -n | head -n 10
			;;

		8)
			echo -n "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): "
			read respond

			if [ "$respond" == "y" ]
			then
				userId=$(awk -F'|' '$2 >= 20 && $2 <=29 && $4 == "programmer" {print $1}' u.user)
				awk -v userId="$userId" -F'\t' '
				BEGIN { split(userId, userIdArr, " ");
				for (i in userIdArr) userIdMap[userIdArr[i]] = 1; }
					{if ($1 in userIdMap) { sum[$2] += $3; cnt[$2]++; }}
				END { for (movieId in sum) if (cnt[movieId] > 0) printf "%d %.5g\n", movieId, sum[movieId]/cnt[movieId]; }
				' u.data | sort -nk1
			fi
			;;

		9)
			echo "Bye!"
			break
			;;
	esac
done
