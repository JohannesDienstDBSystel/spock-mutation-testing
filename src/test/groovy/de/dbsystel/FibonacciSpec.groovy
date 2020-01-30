package de.dbsystel

import de.dbsystel.numbers.Fibonacci
import spock.lang.Specification
import spock.lang.Subject

class FibonacciSpec extends Specification {

    @Subject
    Fibonacci fib = new Fibonacci();

    def "test fibonacci generator"() {
        given: "an instance of the fibonacci generator"
            Fibonacci fib = new Fibonacci()

        when: "the fib sequence for a given input #i is calculated"
            def result = fib.calc(i)

        then: "the expected number is returned"
            result == expected

        where:
             i  || expected
             0  || 0
             2  || 1
            11  || 89
    }
}
