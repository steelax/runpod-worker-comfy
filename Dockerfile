# Use Nvidia CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04 as base

# Prevents prompts from packages asking for user input during installation
ENV DEBIAN_FRONTEND=noninteractive
# Prefer binary wheels over source distributions for faster pip installations
ENV PIP_PREFER_BINARY=1
# Ensures output from python is printed immediately to the terminal without buffering
ENV PYTHONUNBUFFERED=1 

# Install Python, git and other necessary tools
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    git \
    wget

# Clean up to reduce image size
RUN apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git /comfyui

# Change working directory to ComfyUI
WORKDIR /comfyui

ARG SKIP_DEFAULT_MODELS
# Download checkpoints/vae/LoRA to include in image.
RUN if [ -z "$SKIP_DEFAULT_MODELS" ]; then wget -O models/checkpoints/sd_xl_base_1.0.safetensors https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0/resolve/main/sd_xl_base_1.0.safetensors; fi
RUN if [ -z "$SKIP_DEFAULT_MODELS" ]; then wget -O models/vae/sdxl_vae.safetensors https://huggingface.co/stabilityai/sdxl-vae/resolve/main/sdxl_vae.safetensors; fi
RUN if [ -z "$SKIP_DEFAULT_MODELS" ]; then wget -O models/vae/sdxl-vae-fp16-fix.safetensors https://huggingface.co/madebyollin/sdxl-vae-fp16-fix/resolve/main/sdxl_vae.safetensors; fi

RUN wget -O models/checkpoints/leosamsHelloworldXL_helloworldXL70.safetensors https://civitai.com/api/download/models/570138
RUN wget -O models/loras/1987 Action Figure Playset Packaging.safetensors https://civitai.com/models/63521
RUN wget -O models/loras/Aether_Watercolor_and_Ink_v1_SDXL_LoRA.safetensors https://civitai.com/models/190242
RUN wget -O models/loras/artdecopostsdxl.safetensors https://civitai.com/models/390026
RUN wget -O models/loras/ArtfullyMOSAIC_SDXL_V1.safetensors https://civitai.com/models/348840
RUN wget -O models/loras/Caricatures_V2-000007.safetensors https://civitai.com/models/181092
RUN wget -O models/loras/Clay Animation.safetensors https://civitai.com/models/59569
RUN wget -O models/loras/Dragon Ball_XL.safetensors https://civitai.com/models/404867
RUN wget -O models/loras/Felted Doll_v1.0.safetensors https://civitai.com/models/155531
RUN wget -O models/loras/franklinbooth_xl-000006.safetensors https://civitai.com/models/427642
RUN wget -O models/loras/LegoRay.safetensors https://civitai.com/models/331267
RUN wget -O models/loras/Line_Art_SDXL.safetensors https://civitai.com/models/261433
RUN wget -O models/loras/PixarXL.safetensors https://civitai.com/models/188525
RUN wget -O models/loras/PixelArtRedmond-Lite64.safetensors https://civitai.com/models/144684
RUN wget -O models/loras/sk-kru3ger_style.safetensors https://civitai.com/models/129646
RUN wget -O models/instantid/ip-adapter.bin https://huggingface.co/InstantX/InstantID/resolve/main/ip-adapter.bin
RUN wget -O models/insightface/models/antelopev2/1k3d68.onnx https://huggingface.co/MonsterMMORPG/tools/resolve/main/1k3d68.onnx
RUN wget -O models/insightface/models/antelopev2/2d106det.onnx https://huggingface.co/MonsterMMORPG/tools/resolve/main/2d106det.onnx
RUN wget -O models/insightface/models/antelopev2/antelopev2.zip https://huggingface.co/MonsterMMORPG/tools/resolve/main/antelopev2.zip
RUN wget -O models/insightface/models/antelopev2/genderage.onnx https://huggingface.co/MonsterMMORPG/tools/resolve/main/genderage.onnx
RUN wget -O models/insightface/models/antelopev2/glintr100.onnx https://huggingface.co/MonsterMMORPG/tools/resolve/main/glintr100.onnx
RUN wget -O models/insightface/models/antelopev2/scrfd_10g_bnkps.onnx https://huggingface.co/MonsterMMORPG/tools/resolve/main/scrfd_10g_bnkps.onnx
RUN wget -O models/controlnet/faceIDctrlnet.safetensors https://huggingface.co/InstantX/InstantID/resolve/main/ControlNetModel/diffusion_pytorch_model.safetensors

RUN git clone https://github.com/Fannovel16/comfyui_controlnet_aux.git custom_nodes/comfyui_controlnet_aux
RUN git clone https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes.git custom_nodes/Derfuu_ComfyUI_ModdedNodes
RUN git clone https://github.com/cubiq/ComfyUI_InstantID custom_nodes/ComfyUI_InstantID
RUN git clone https://github.com/steelax/sdxl_prompt_styler.git custom_nodes/sdxl_prompt_styler
RUN git clone https://github.com/BadCafeCode/masquerade-nodes-comfyui.git custom_nodes/masquerade-nodes-comfyui





# Install ComfyUI dependencies
RUN pip3 install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121 \
    && pip3 install --no-cache-dir xformers==0.0.21 \
    && pip3 install -r requirements.txt

# Install runpod
RUN pip3 install runpod requests

# Support for the network volume
ADD src/extra_model_paths.yaml ./

# Go back to the root
WORKDIR /

# Add the start and the handler
ADD src/start.sh src/rp_handler.py test_input.json ./
RUN chmod +x /start.sh

# Start the container
CMD /start.sh
