import time


"""

lo q logre concluir de los archivos ´.bin´, ´.hex´
es que tienen la siguiente estructura

    [32]\n
    [32]\n

solo q estan codificados en bin, hex

"""

with open("def.text.bin", "rb") as db:
    for chuck in db:
        n = 0
        for i in range(32):
            t = 1 if chuck[i] == b"1" else 0
            n = (n << 1) | t

        print("%08x" % n)
        time.sleep(2)

