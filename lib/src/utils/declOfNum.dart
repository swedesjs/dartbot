String declOfNum(num inputNumber, List<String> titleList) =>
    titleList[inputNumber % 10 == 1 && inputNumber % 100 != 11
        ? 0
        : inputNumber % 10 >= 2 && inputNumber % 10 <= 4 && inputNumber % 100 < 10 ||
                inputNumber % 100 >= 20
            ? 1
            : 2];
