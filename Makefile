pp_tar = pp@1.0.11.tgz
pp_url = https://adi.onl/pp/$(pp_tar)
TMP_PORT = 7272

.PHONY: video-gallery-generator.sh

clean:
	rm -rf *.mp4* *.vtt* video/ index.html *.pp pp-tmp

example-video:
	wget \
	https://rojenzaman.github.io/video-gallery/file_example_MP4_480_1_5MG.mp4 \
	https://rojenzaman.github.io/video-gallery/file_example_MP4_480_1_5MG.vtt \
	https://rojenzaman.github.io/video-gallery/grb_2.mp4 \
	https://rojenzaman.github.io/video-gallery/mov_bbb.mp4 \
	https://rojenzaman.github.io/video-gallery/mov_bbb.vtt \
	https://rojenzaman.github.io/video-gallery/sample_640x360.mp4 \
	https://rojenzaman.github.io/video-gallery/small.mp4

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
