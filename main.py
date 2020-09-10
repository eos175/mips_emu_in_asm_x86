import time


"""

lo q logre concluir de los archivos ´.bin´, ´.hex´
es que tienen la siguiente estructura

    [32]\n
    [32]\n

solo q estan codificados en bin, hex

"""

tmp = [605028355, 605093889, 605159427, 605356033, 604241984, 604307480, 1006702602, 874917544, 14369, 
  202375792, 135266358, 604242048, 604307480, 1006702602, 874919600, 14369, 202375792, 135266358, 
  604241920, 604307562, 1006702602, 874921656, 14369, 202375792, 135266358, 604242048, 604307562, 
  1006702602, 874932928, 14369, 202375792, 135266358]

with open("def.text.hex", "r") as db:
    for i, chuck in zip(tmp, db):
        n = int.from_bytes(
            bytes.fromhex(chuck), byteorder="big"
        )
        print("%s -> %d == %d" % (chuck[:-1], n, n == i))
        input()
        """
        n = 0
        for i in range(32):
            t = 1 if chuck[i] == b"1" else 0
            n = (n << 1) | t

        print("%08x" % n)
        time.sleep(2)
        """
