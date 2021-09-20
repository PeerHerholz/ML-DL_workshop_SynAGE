#Generate Dockerfile.

#!/bin/sh

 set -e

generate_docker() {
  docker run --rm kaczmarj/neurodocker:0.6.0 generate docker \
             --base neurodebian:stretch-non-free \
             --pkg-manager apt \
             --install git num-utils gcc g++ curl build-essential nano graphviz tree \
                     git-annex-standalone emacs-nox nano less ncdu \
                     tig git-annex-remote-rclone\
             --user=ml_dl_synage\
             --miniconda \
                conda_install="python=3.6 numpy scipy nilearn nibabel pandas nb_conda 
                               nb_conda_kernels nbconvert nbformat jupyter jupyterlab" \
                pip_install='seaborn tensorflow scikit-image scikit-learn keras tensorboard myst-nb 
                             jupytext ghp-import jupyter-book==0.11.3 pillow graphviz
                             pyglet nobrainer plotly sphinx-book-theme jupyter_contrib_nbextensions
                             RISE statsmodels pingouin vtk datalad[full] nbval' \
                create_env='ml_dl_synage' \
                activate=true \
             --env LD_LIBRARY_PATH="/opt/miniconda-latest/envs/ml_dl_synage:$LD_LIBRARY_PATH" \
             --run-bash "source activate ml_dl_synage && jupyter nbextension enable rise/main && jupyter nbextension enable spellchecker/main" \
             --user=root \
             --run 'mkdir /data && chmod 777 /data && chmod a+s /data' \
             --run 'mkdir /output && chmod 777 /output && chmod a+s /output' \
             --user=ml_dl_synage \
             --run 'printf "[user]\n\tname = peerherholz\n\temail = herholz.peer@gmail.com\n" > ~/.gitconfig' \
             --run-bash 'source activate ml_dl_synage && cd /data && datalad install -r ///workshops/nih-2017/ds000114 && cd ds000114 && datalad update -r && datalad get -r sub-01/ses-test/anat sub-01/ses-test/func/*fingerfootlips*' \
             --run 'curl -L https://files.osf.io/v1/resources/fvuh8/providers/osfstorage/580705089ad5a101f17944a9 -o /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz && tar xf /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz -C /data/ds000114/derivatives/fmriprep/. && rm /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c.tar.gz && find /data/ds000114/derivatives/fmriprep/mni_icbm152_nlin_asym_09c -type f -not -name ?mm_T1.nii.gz -not -name ?mm_brainmask.nii.gz -not -name ?mm_tpm*.nii.gz -delete' \
             --copy . /home/ml_dl_synage \
             --user=root \
             --run 'chown -R ml_dl_synage /home/ml_dl_synage/lecture' \
             --run 'rm -rf /opt/conda/pkgs/*' \
             --user=ml_dl_synage \
             --run 'mkdir -p ~/.jupyter && echo c.NotebookApp.ip = \"0.0.0.0\" > ~/.jupyter/jupyter_notebook_config.py' \
             --workdir /home/ml_dl_synage/lecture \
             --cmd "jupyter-notebook --port=8888 --no-browser --ip=0.0.0.0"
}

# generate files
generate_docker > Dockerfile
