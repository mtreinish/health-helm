#!/usr/bin/env python3

import datetime
import math
import sys
import xml.etree.ElementTree as ET

try:
    from subunit import iso8601
    from subunit import v2
except ImportError:
    print("You need the python-subunit python package installed to use this "
          "utility")
    sys.exit(1)

STATUS_CODES = frozenset([
    'exists',
    'fail',
    'skip',
    'success',
    'uxsuccess',
    'xfail',
])


def junitxml_to_subunit(xml_input=sys.stdin, output=sys.stdout):
    output = v2.StreamResultToBytes(output)
    tree = ET.parse(xml_input)
    start_time = datetime.datetime.now(iso8601.UTC)
    for testcase in tree.findall('.//testcase'):
        test_id = testcase.attrib.get('name', None)
        test_class = testcase.attrib.get('classname', None)
        if test_class:
            if test_id:
                test_id = '.'.join([test_class, test_id])
            else:
                test_id = test_class
        test_metadata = None
        test_status = None
        skipped = None
        failure = None
        test_time = to_timedelta(testcase.attrib.get('time'))
        skipped = testcase.find('.//skipped')
        failure = testcase.find('.//failure')
        attachment = None
        if skipped is not None:
            test_status = "skip"
            attachment = skipped.attrib.get('message', None)
        elif failure is not None:
            test_status = "fail"
            attachment = failure.attrib.get('message', None)
        else:
            test_status = "success"
        write_test(output, test_id, test_status, test_metadata, test_time,
                   start_time, attachment)
        start_time = start_time + test_time


def write_test(output, test_id, test_status, metadatas, test_time, start_time,
               attachment):
    if test_status not in STATUS_CODES:
        raise TypeError('Invalid test status %s' % test_status)
    kwargs = {}
    if metadatas:
        if 'tags' in metadatas:
            tags = metadatas['tags']
            kwargs['test_tags'] = tags.split(',')
        if 'attrs' in metadatas:
            test_id = test_id + '[' + metadatas['attrs'] + ']'
    kwargs['test_id'] = test_id
    kwargs['timestamp'] = start_time
    kwargs['test_status'] = "inprogress"
    output.status(**kwargs)
    kwargs['timestamp'] = start_time + test_time
    kwargs['test_status'] = test_status
    if attachment:
        kwargs['mime_type'] = 'text/plain'
        if test_status == 'fail':
            kwargs['file_name'] = 'traceback'
        else:
            kwargs['file_name'] = 'reason'
        kwargs['file_bytes'] = attachment.encode('utf8')
    output.status(**kwargs)


def to_timedelta(value):
    if value is None:
        return None
    sec = float(value)
    if math.isnan(sec):
        return None
    return datetime.timedelta(seconds=sec)


if __name__ == '__main__':
    if len(sys.argv) >= 2:
        xml_in = open(sys.argv[1], 'r')
    else:
        xml_in = sys.stdin
    try:
        junitxml_to_subunit(xml_in, sys.stdout)
    finally:
        xml_in.close()
