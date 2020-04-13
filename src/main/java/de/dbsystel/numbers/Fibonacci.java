/*
 * Copyright 2020 DB Systel GmbH
 * SPDX-License-Identifier: Apache-2.0
 */

package de.dbsystel.numbers;

public class Fibonacci {

    public Integer calc(Integer i) {
        if (i == 0) {
            return 0;
        }

        if (i <= 2) {
            return 1;
        }

        return calc(i - 1) + calc(i - 2);
    }

}