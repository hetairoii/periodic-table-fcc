#!/bin/bash
#commit2
#commit3
#commit4
#commit5

is_number() {
    [[ $1 =~ ^-?[0-9]+(\.[0-9]+)?$ ]]
}

if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  PSQL="psql --username=freecodecamp --dbname=periodic_table --tuples-only -c"
  if is_number "$1"; 
  then
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE atomic_number=$1;")
  else
    ELEMENT=$($PSQL "SELECT * FROM elements WHERE symbol='$1' OR name='$1';")
  fi

  if [[ -z $ELEMENT ]]
  then
    echo "I could not find that element in the database."
  else
    IFS='|' read -r atomic_number symbol name <<< "$ELEMENT"
    atomic_number=$(echo "$atomic_number" | xargs)
    symbol=$(echo "$symbol" | xargs)
    name=$(echo "$name" | xargs)

    PROPERTIES=$($PSQL "SELECT type_id,atomic_mass,melting_point_celsius,boiling_point_celsius  FROM properties WHERE atomic_number=$atomic_number;")
    IFS='|' read -r type_id atomic_mass melting_point boiling_point <<< "$PROPERTIES"
    type_id=$(echo "$type_id" | xargs)
    atomic_mass=$(echo "$atomic_mass" | xargs)
    melting_point=$(echo "$melting_point" | xargs)
    boiling_point=$(echo "$boiling_point" | xargs)

    TYPES=$($PSQL "SELECT type  FROM types WHERE type_id=$type_id;")
    IFS='|' read -r type <<< "$TYPES"
    type=$(echo "$type" | xargs)

    echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
  fi
fi