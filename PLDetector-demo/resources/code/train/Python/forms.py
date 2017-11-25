from __future__ import unicode_literals

from django import forms

from .models import Photo


class PhotoForm(forms.ModelForm):
    class Meta:
        model = Photo
        fields = ('image', 'content', )
        # exclude = ('filtered_image', )    # 사용해야할 모델 필드가 그렇지 않은 것보다 많을경우 역으로 사용하지 않을 필드를 지정