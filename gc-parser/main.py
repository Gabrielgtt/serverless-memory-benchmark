import argparse
import logging
import parser

def load_arguments():
    parser = argparse.ArgumentParser(description='Parse metrics from JVM GC logs in Java 11')

    parser.add_argument('--gc', '-g', type=str, default="G1",
            help='The name of the GC used (default: assumes G1)')

    parser.add_argument('--log_file', '-l', type=str, required=True,
            help='Filepath for the GC log')

    parser.add_argument('--id', '-i', type=str, required=True,
            help='ID used to identify all output files')

    return parser.parse_args()

if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format='[%(asctime)s] %(message)s')
    args = load_arguments()

    gc_name = args.gc
    if gc_name == parser.GCParsers['G1'].value:
        gc_parser = parser.G1()
    elif gc_name == parser.GCParsers['Shenandoah'].value:
        gc_parser = parser.Shenandoah()
    elif gc_name == parser.GCParsers['Epsilon'].value:
        gc_parser = parser.Epsilon()
    else:
        raise Exception('Unable to identify a GC Parser for the gc {}'.format(gc_name))

    log_file = args.log_file
    output_id = args.id

    parser.parse_file(log_file, gc_parser, output_id)

