pp_tar = pp@1.0.11.tgz
pp_url = https://adi.onl/pp/$(pp_tar)
TMP_PORT = 7272

.PHONY: video-gallery-generator.sh

clean:
	rm -rf *.mp4* *.vtt* video/ index.html *.pp pp-tmp

example-video:
	wget \
	https://static.fsf.org/nosvn/videos/escape-to-freedom/videos/escape-to-freedom-360p.mp4 \
	https://static.fsf.org/nosvn/videos/escape-to-freedom/captions/escape-to-freedom_en.vtt \
	https://static.fsf.org/nosvn/videos/fight-to-repair/videos/Fight-to-Repair-360p.mp4 \
	https://static.fsf.org/nosvn/videos/fight-to-repair/captions/fight-to-repair_en.vtt

video-gallery-generator.sh: opt/pp/pp
	bin/preprocessor.sh video-gallery-generator.sh

opt/pp/pp:
	bin/install-pp.sh $(pp_url) $(pp_tar)

http:
	python -m http.server $(TMP_PORT)

test:
	$(MAKE) clean
	$(MAKE) example-video
	$(MAKE) video-gallery-generator.sh
	./video-gallery-generator.sh -t "Testing"
	$(MAKE) http
