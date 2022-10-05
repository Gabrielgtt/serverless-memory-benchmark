import abc
import re
import subprocess
import logging
from enum import Enum

class Parser(metaclass=abc.ABCMeta):
    @abc.abstractmethod
    def pauses(self, log_file: str) -> (str, list):
        raise NotImplementedError

    @abc.abstractmethod
    def allocation(self, log_file: str) -> (str, list):
        raise NotImplementedError

    def general(self, log_file: str) -> (str, list):
        cmds = [
                ['cat', log_file],
                ['grep', 'GC([0-9]*)', '-o'],
                ['tail', '-1'],
                ['grep', '-o', '[0-9]*']
        ]
        gc_count = run_cmds(cmds) 
        gc_count = str(int(gc_count) + 1) # The count starts at 0, so add 1
        logging.info('GC count: {}'.format(gc_count))

        header = 'gc_count'

        return header, [gc_count]


class Epsilon(Parser):
    def __init__(self):
        logging.info('Assuming Epsilon logs')

    def general(self, log_file):
        return "", []

    def pauses(self, log_file):
        return "", []

    def allocation(self, log_file):
        cmds = [
                ['cat', log_file],
                ['grep', 'Heap: [0-9]*M'],
                ['grep', '\[[0-9\.]*s\]\|[0-9]*[MKG]', '-o'],
                ['xargs', '-n', '4', 'echo'],
                ['cut', '-d ', '-f1,4'],
                ['sed', 's/\[\|\]\|s//g']
        ]

        alloc = run_cmds(cmds).strip().split('\n')

        header = "ts_s,heap_before_mb,heap_after_mb"
        lines = []

        for line in alloc:
            ts, heap = line.split(" ")
            number = int(heap[:-1])

            if heap[-1] == 'G':
                number *= 1024
            elif heap[-1] == 'K':
                number /= 1024

            number = round(number)

            lines.append(ts + ',' + str(number) + ',' + str(number))

        return header, lines



class G1(Parser):
    def __init__(self):
        logging.info('Assuming G1GC logs')

    def pauses(self, log_file):
        cmds = [
                ['cat', log_file],
                ['grep', '\[gc[ ]*\] GC' ],
                ['awk', '{{print $NF}}'],
                ['sed', 's/ms//g'],
                ['sed', 's/,/./g']
            ]
        pause_times = run_cmds(cmds).split('\n')
        pause_times.pop() # Last element is always a space

        pauses = []

        for p in pause_times:
            pauses += ["stw,{}".format(p)]
       
        header = "type,pause_time_ms"
        return header, pauses

    def allocation(self, log_file):
        cmds = [
                ['cat', log_file],
                ['grep', '[0-9]*M->[0-9]*M'],
                ['grep', '\[[0-9\.s]*\]\|[0-9]*M->[0-9]*M', '-o', '-n'],
                ['sed', 's/M\|\[\|\]\|s//g'],
                ['sed', 's/,/./g'],
                ['sed', 's/->/,/g']
        ]
        alloc = run_cmds(cmds).strip().split('\n')

        header = "ts_s,heap_before_mb,heap_after_mb,alloc_since_last_gc,time_since_last_gc"
        lines = ["" for x in range((len(alloc)+1)//2)]

        for i, line in enumerate(alloc):
            index, info = line.split(":")
            index = int(index) - 1
            if lines[index] != "":
                lines[index] += ",";
            lines[index] += info

        ts_last = 0
        heap_last = 0
        for i in range(len(lines)):
            ts, bef, aft = lines[i].split(',')
            ts = float(ts)
            bef = int(bef)
            aft = int(aft)

            alloc_since_last = bef - heap_last
            time_since_last = ts - ts_last

            ts_last = ts
            heap_last = aft

            lines[i] += ",{},{:.3f}".format(alloc_since_last, time_since_last)


        return header, lines

class Shenandoah(Parser):
    def __init__(self):
        logging.info('Assuming ShenandoahGC logs')

    def pauses(self, log_file):
        cmds_stw_pauses = [
                ['cat', log_file],
                ['grep', '\[gc[ ]*\] GC' ],
                ['grep', 'Pause' ],
                ['awk', '{{print $NF}}'],
                ['sed', 's/ms//g'],
                ['sed', 's/,/./g']
        ]
        stw_pauses = run_cmds(cmds_stw_pauses).split('\n')
        stw_pauses.pop() # Last element is always a space
        logging.info("#STW phases: {}".format(len(stw_pauses)))

        cmds_conc_pauses = [
                ['cat', log_file],
                ['grep', '\[gc[ ]*\] GC' ],
                ['grep', 'Concurrent' ],
                ['awk', '{{print $NF}}'],
                ['sed', 's/ms//g'],
                ['sed', 's/,/./g']
        ]
        conc_pauses = run_cmds(cmds_conc_pauses).split('\n')
        conc_pauses.pop() # Last element is always a space
        logging.info("#Concurrent phases: {}".format(len(conc_pauses)))

        pauses = []

        for p in stw_pauses:
            pauses += ["stw,{}".format(p)]
        for p in conc_pauses:
            pauses += ["conc,{}".format(p)]
       
        header = "type,pause_time_ms"
        return header, pauses

    def allocation(self, log_file):
        cmds = [
                ['cat', log_file],
                ['grep', '[0-9]*M->[0-9]*M'],
                ['grep', '\[[0-9\.s]*\]\|[0-9]*M->[0-9]*M', '-o', '-n'],
                ['sed', 's/M\|\[\|\]\|s//g'],
                ['sed', 's/,/./g'],
                ['sed', 's/->/,/g']
        ]
        alloc = run_cmds(cmds).strip().split('\n')

        header = "ts_s,heap_before_mb,heap_after_mb,alloc_since_last_gc,time_since_last_gc"
        lines = ["" for x in range((len(alloc)+1)//2)]

        for i, line in enumerate(alloc):
            index, info = line.split(":")
            index = int(index) - 1
            if lines[index] != "":
                lines[index] += ",";
            lines[index] += info

        ts_last = 0
        heap_last = 0
        for i in range(len(lines)):
            ts, bef, aft = lines[i].split(',')
            ts = float(ts)
            bef = int(bef)
            aft = int(aft)

            alloc_since_last = bef - heap_last
            time_since_last = ts - ts_last

            ts_last = ts
            heap_last = aft

            lines[i] += ",{},{:.3f}".format(alloc_since_last, time_since_last)

        return header, lines

class GCParsers(Enum):
    G1 = 'G1'
    Shenandoah = 'Shenandoah'
    Epsilon = 'Epsilon'


def run_cmds(cmds):
    first = True
    for cmd in cmds:
        if first:
            sp = subprocess.Popen(cmd, stdout=subprocess.PIPE)
            first = False
        else:
            sp = subprocess.Popen(cmd, stdin=previous_stdout, stdout=subprocess.PIPE)

        previous_stdout = sp.stdout

    return previous_stdout.read().decode('utf-8')


def write_output(header, lines, output_id, metric_name):
    output_filepath = '{}-{}.csv'.format(output_id, metric_name)

    with open(output_filepath, 'w') as out:
        out.write(header + '\n')
        for line in lines:
            out.write(line + '\n')


def parse_file(log_file, parser: Parser, output_id):
    logging.info('Parsing file {}'.format(log_file))

    # Agreagated metrics that all GCs have
    header, lines = parser.general(log_file)
    write_output(header, lines, output_id, "general")

    # Pause time metrics
    header, lines = parser.pauses(log_file)
    write_output(header, lines, output_id, "gc")

    # Allocation metrics
    header, lines = parser.allocation(log_file)
    write_output(header, lines, output_id, "alloc")

