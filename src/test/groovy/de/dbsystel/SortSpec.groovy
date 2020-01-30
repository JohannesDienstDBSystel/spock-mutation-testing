package de.dbsystel

import de.dbsystel.sort.Sort
import spock.lang.Specification


class SortSpec extends Specification {

    def "test Sort"() {
        given: "an instance of Sort"
            def Sort = new Sort()
        when: "the given list #list is sorted"
            def result = Sort.sort(list)
        then: "the result is as #expected"
            result == expected
        where: ""
            list      || expected
            []        || []
            [5]       || [5]
            [2,1,3,8] || [1,2,3,8]
    }
}
