import sys

print("*** "+sys.argv[0]+" ***")
print(" ** converting "+ sys.argv[1]+" to uncompressed "+sys.argv[2] +" ")
with open(sys.argv[1],'rb') as f, open(sys.argv[2], 'wb') as out_buf:
    byte = f.read(1)
    while byte:
        # Do stuff with byte.
        byte_value= int.from_bytes(byte,"big")
        if byte_value == 237: 
            len_byte = int.from_bytes(f.read(1),"big")
            
            if len_byte != 0:
              byte2 = f.read(1)
              for x in range(len_byte):
                  out_buf.write(byte2)
        else:
          out_buf.write(byte)
        byte = f.read(1)
        
out_buf.close()