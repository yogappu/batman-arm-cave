from hashlib import sha3_256, sha3_512, shake_128, shake_256

# 32 bytes of 0xFF
input_bytes = bytes([0xFF] * 1024)

# Compute hashes
sha3_256_hash = sha3_256(input_bytes).hexdigest()
sha3_512_hash = sha3_512(input_bytes).hexdigest()
shake128_hash = shake_128(input_bytes).hexdigest(32)  # 32-byte output
shake256_hash = shake_256(input_bytes).hexdigest(1024)  # 64-byte output

# Print results
print(f"SHA3-256: {sha3_256_hash}")
print(f"SHA3-512: {sha3_512_hash}")
print(f"SHAKE128 (32 bytes): {shake128_hash}")
print(f"SHAKE256 (64 bytes): {shake256_hash}")