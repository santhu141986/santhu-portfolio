import numpy as np
import streamlit as st # this is for webapp development
from tensorflow.keras.models import load_model
from tensorflow.keras.preprocessing import image
from PIL import Image 

model = load_model('brain_tumor_prediction_model_20_epochs.h5') # load the save model 

def predict_tumor(img): # this function is for prediction of loaded image
    image_path = img
    img = image.load_img(image_path, target_size=(150,150), color_mode='grayscale')
    img_array = image.img_to_array(img)/255.0
    img_array = np.expand_dims(img_array,axis=0)

    prediction = model.predict(img_array)
    if(prediction[0][0] > 0.5):
        return "Tumor"
    else:
        return "No Tumor"
    
st.markdown(
    """
    <style>
    .stApp {
        background-color: black;
        color: white;
    }
    </style>
    """,
    unsafe_allow_html=True,
)
def main():     # in main function image is loaded and passed to the prediction function
    st.title("Brain Tumor Detection")
    st.write("Upload an MRI image to Predict")
    uploaded_file = st.file_uploader("Choose MRI File image..", type=["jpg", "jpeg", 'png']) # allows to upload the image 
    if uploaded_file is not None:# if the iuploaded file is not empty then execute the below
        # st.image(uploaded_file, caption = "Uploaded Image", use_container_width=True)
        # st.write("Processing...")

        # img = Image.open(uploaded_file)
        result = predict_tumor(uploaded_file) # pass the uploaded image to prediction function
        st.write(f"** Prediction:** {result}") # get the result and prin the result on webpage
if __name__ == '__main__':
    main()
