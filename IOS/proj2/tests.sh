#bin/bash
# Hromadné testy pro 2. projekt IOS 2024/25
# Potřebuje mít ve stejném adresáři test od @ondar.irl (ios_proj2_test.py) a binárku
# Pro spuštění je potřeba spustit chmod +x tests.sh, poté ./tests.sh
# xzmatlv00 / vojcekz (Discord)
# 1. verze


##########################################š
# UPRAVENÍ POČTU ITERACÍ A SOUBORU
iterace_zadani=1000
iterace_max=10
iterace_random=100
TEST_OUTPUT_FILE="test_output.txt"
##########################################š

echo -e "\033[1mPříprava\033[0m"
echo "------------------------------------"

if [ -e $TEST_OUTPUT_FILE ]; then
    read -p "Soubor $TEST_OUTPUT_FILE už existuje. Chceš ho nahradit? (y/n)" odpoved
    case $odpoved in
        y )
            confirm="a"
            echo "Soubor $TEST_OUTPUT_FILE bude nahrazen dočasným souborem pro testy a jeho obsah bude vymazán po stisknutí enter."
            while [[ "$confirm" != "" ]] ;
            do
                read confirm
            done
            break;;
        n )
            echo "Změňte proměnnou TEST_OUTPUT_FILE nebo si zálohujte soubor $TEST_OUTPUT_FILE."
            echo "Ukončování testů. "
            exit;;
    esac
fi
touch "$TEST_OUTPUT_FILE"

skip_warnings=0

echo -e "\033[1mZahajování testů\033[0m"
echo "------------------------------------"
echo -e "\033[1mPrvní sada: Vstupy ze zadání\033[0m"

for ((i=1; i<=iterace_zadani; i++));
do
    echo "Iterace $i: " > $TEST_OUTPUT_FILE
    python3 ios_proj2_test.py run ./proj2 4 4 10 10 10 >> "$TEST_OUTPUT_FILE"
    sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
    if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
        echo -e "\033[31mPři iteraci $i s argumenty ze zadání se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
        echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
        exit 1
    fi

    if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
        echo -e "\033[33mPři iteraci $i s argumenty ze zadání byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y = y pro všechny budoucí z této sady)?"
        while true; do
            read odpoved
            case "$odpoved" in
                y ) 
                    echo "Pokračování testů... "
                    break;;
                Y ) 
                    echo "Pokračování testů... "
                    skip_warnings=1
                    break;;
                n )
                    echo "Ukončování scriptu. "
                    exit;;
                * ) 
                    echo "Zadej prosím y, Y nebo n.";;
            esac
        done
    fi
done

echo -e "\033[32mPrvní sada testů prošla bez erroru. \033[0m"
echo "------------------------------------"
skip_warnings=0
echo -e "\033[1mDruhá sada: maximální hodnoty\033[0m"

for ((i=1; i<=iterace_max; i++));
do
    echo "Iterace $i: " > $TEST_OUTPUT_FILE
    python3 ios_proj2_test.py run ./proj2 9999 9999 100 10000 1000 >> "$TEST_OUTPUT_FILE"
    sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
    if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
        echo -e "\033[31mPři iteraci $i s maximálními argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
        echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
        exit 1
    fi

    if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
        echo -e "\033[33mPři iteraci $i s maximálními argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
        while true; do
            read odpoved
            case "$odpoved" in
                y ) 
                    echo "Pokračování testů... "
                    break;;
                Y ) 
                    echo "Pokračování testů... "
                    skip_warnings="1"
                    break;;
                n )
                    echo "Ukončování scriptu. "
                    rm $TEST_OUTPUT_FILE
                    exit;;
                * ) 
                    echo "Zadej prosím y, Y nebo n.";;
            esac
        done
    fi
done


echo -e "\033[32mDruhá sada testů prošla bez erroru. \033[0m"
echo "------------------------------------"
skip_warnings=0
echo -e "\033[1mTřetí sada: Nulové argumenty. \033[0m"

echo "Iterace 1: " > $TEST_OUTPUT_FILE
python3 ios_proj2_test.py run ./proj2 0 10 10 10 10 >> "$TEST_OUTPUT_FILE"
sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
    echo -e "\033[31mPři iteraci 1 s nulovými argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
    echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
    exit 1
fi

if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
    echo -e "\033[33mPři iteraci 2 s nulovými argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
    grep 'Warning' $TEST_OUTPUT_FILE
    echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
    while true; do
        read odpoved
        case "$odpoved" in
            y ) 
                echo "Pokračování testů... "
                break;;
            Y ) 
                echo "Pokračování testů... "
                skip_warnings="1"
                break;;
            n )
                echo "Ukončování scriptu. "
                exit;;
            * ) 
                echo "Zadej prosím y, Y nebo n.";;
        esac
    done
fi

echo "Iterace 2: " > $TEST_OUTPUT_FILE
python3 ios_proj2_test.py run ./proj2 10 0 9 10 10 >> "$TEST_OUTPUT_FILE"
sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
    echo -e "\033[31mPři iteraci 2 s nulovými argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
    echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
    exit 1
fi

if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
    echo -e "\033[33mPři iteraci 2 s nulovými argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
    while true; do
        read odpoved
        case "$odpoved" in
            y ) 
                echo "Pokračování testů... "
                break;;
            Y ) 
                echo "Pokračování testů... "
                skip_warnings="1"
                break;;
            n )
                echo "Ukončování scriptu. "
                exit;;
            * ) 
                echo "Zadej prosím y, Y nebo n.";;
        esac
    done
fi

echo "Iterace 3: " > $TEST_OUTPUT_FILE
python3 ios_proj2_test.py run ./proj2 0 0 10 10 10 >> "$TEST_OUTPUT_FILE"
sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
    echo -e "\033[31mPři iteraci 3 s nulovými argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
    echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
    exit 1
fi

if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
    echo -e "\033[33mPři iteraci 3 s nulovými argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
    while true; do
        read odpoved
        case "$odpoved" in
            y ) 
                echo "Pokračování testů... "
                break;;
            Y ) 
                echo "Pokračování testů... "
                skip_warnings="1"
                break;;
            n )
                echo "Ukončování scriptu. "
                exit;;
            * ) 
                echo "Zadej prosím y, Y nebo n.";;
        esac
    done
fi

echo "Iterace 4: " > $TEST_OUTPUT_FILE
python3 ios_proj2_test.py run ./proj2 4 4 10 0 10 >> "$TEST_OUTPUT_FILE"
sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
    echo -e "\033[31mPři iteraci 4 s nulovými argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
    echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
    exit 1
fi

if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
    echo -e "\033[33mPři iteraci 4 s nulovými argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
    while true; do
        read odpoved
        case "$odpoved" in
            y ) 
                echo "Pokračování testů... "
                break;;
            Y ) 
                echo "Pokračování testů... "
                skip_warnings="1"
                break;;
            n )
                echo "Ukončování scriptu. "
                exit;;
            * ) 
                echo "Zadej prosím y, Y nebo n.";;
        esac
    done
fi


echo "Iterace 5: " > $TEST_OUTPUT_FILE
python3 ios_proj2_test.py run ./proj2 4 4 10 10 0 >> "$TEST_OUTPUT_FILE"
sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
    echo -e "\033[31mPři iteraci 5 s nulovými argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
    echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
    exit 1
fi

if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
    echo -e "\033[33mPři iteraci 5 s nulovými argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
    while true; do
        read odpoved
        case "$odpoved" in
            y ) 
                echo "Pokračování testů... "
                break;;
            Y ) 
                echo "Pokračování testů... "
                skip_warnings="1"
                break;;
            n )
                echo "Ukončování scriptu. "
                exit;;
            * ) 
                echo "Zadej prosím y, Y nebo n.";;
        esac
    done
fi


echo -e "\033[32mTřetí sada testů prošla bez erroru. \033[0m"
echo "------------------------------------"


skip_warnings=0
echo -e "\033[1mČtvrtá sada: náhodné hodnoty\033[0m"

for ((i=1; i<=iterace_random; i++));
do
    n=$((RANDOM % 10000))
    o=$((RANDOM % 10000))
    k=$(((RANDOM % 98)+3))
    ta=$((RANDOM % 10001))
    tp=$((RANDOM % 1001))
    echo "Iterace $i, hodnoty: n=$n, o=$o, k=$k, ta=$ta, tp=$tp: " > $TEST_OUTPUT_FILE
    python3 ios_proj2_test.py run ./proj2 $n $o $k $ta $tp >> "$TEST_OUTPUT_FILE"
    sed -r -i 's/\x1B\[[0-9;]*[mK]//g' "$TEST_OUTPUT_FILE"
    if ! grep -q 'No errors found' $TEST_OUTPUT_FILE; then
        echo -e "\033[31mPři iteraci $i s náhodnými argumenty se vyskytl \033[1merror\033[22m (podle testů ios_proj2_test.py). \033[0m"
        echo "Vystup chybneho testu je v souboru $TEST_OUTPUT_FILE"
        exit 1
    fi

    if grep -q 'Warning' $TEST_OUTPUT_FILE && [ "$skip_warnings" == 0 ]; then
        echo -e "\033[33mPři iteraci $i s náhodnými argumenty byl(y) podle testů zaznamenán \033[1mwarning(y)\033[22m: "
        grep 'Warning' $TEST_OUTPUT_FILE
        echo -e "\033[0mChcete pokračovat v testech (y/n, Y-y pro všechny budoucí z této sady)?"
        while true; do
            read odpoved
            case "$odpoved" in
                y ) 
                    echo "Pokračování testů... "
                    break;;
                Y ) 
                    echo "Pokračování testů... "
                    skip_warnings="1"
                    break;;
                n )
                    echo "Ukončování scriptu. "
                    exit;;
                * ) 
                    echo "Zadej prosím y, Y nebo n.";;
            esac
        done
    fi
done


echo -e "\033[32mČtvrtá sada testů prošla bez erroru. \033[0m"
echo "------------------------------------"



rm $TEST_OUTPUT_FILE
echo -e "\033[32;1mVšechny testy prošli bez erroru. \033[0m"