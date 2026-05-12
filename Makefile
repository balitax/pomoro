.PHONY: generate open clean

# Generate .xcodeproj dari project.yml
generate:
	xcodegen generate --spec project.yml

# Generate lalu langsung buka di Xcode
open: generate
	open Pomoro.xcodeproj

# Hapus generated project (aman, bisa di-regenerate kapan saja)
clean:
	rm -rf Pomoro.xcodeproj

# Cek project.yml valid sebelum generate
lint:
	xcodegen dump --spec project.yml --type json > /dev/null && echo "✅ project.yml valid"
