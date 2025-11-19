# Fathom-DeepResearch - AMD MI50 vLLM Setup

This fork enables Fathom-DeepResearch to work with vLLM on AMD MI50 GPUs using ROCm.

## Changes from Original

- Modified API calls to use vLLM's `/v1/completions` endpoint instead of SGLang's `/generate`
- Added response format conversion from OpenAI format to expected format
- Fixed model naming for vLLM compatibility
- Removed SGLang dependency

## Requirements

- **Hardware**: AMD MI50 GPU (gfx906 architecture)
- **Software**: 
  - ROCm 6.3.3
  - Docker with GPU support
  - Python 3.12+

## Quick Start


