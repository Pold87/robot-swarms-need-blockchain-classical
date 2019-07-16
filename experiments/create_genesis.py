import sys

outfile=sys.argv[1]

num_robots = int(sys.argv[2])
used_nodes = [sys.argv[3], sys.argv[4]]

# Threshold; all robot ids below this value will be run on node 1, the
# rest on node 2

# For now this script only works with 20 robots;
# I'll have to write it for 100 robots

with open(outfile, 'w') as f:


    f.write("""{
  "nonce": "0x0000000000000001",
    "mixhash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "difficulty": "0x1000",
    "alloc": {
	"ADDRESS": {
	    "balance": "100000000000000000000000"
	}
    },
    "coinbase": "0xcbfbd4c79728b83eb7c3aa50455a78ba724c53ae",
    "timestamp": "0x00",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "extraData": "0x",
    "gasLimit": "0x8000000"    
}""")

    
    for i in xrange(num_robots):
        if (i < t1):
            node = used_nodes[0]
        else:
            node = used_nodes[1]
        
        f.write(str(i) + ' ' + str(node) + '\n')
            
    
