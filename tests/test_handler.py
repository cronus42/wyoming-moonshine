from wyoming_moonshine.handler import MoonshineAsrHandler


def test_build_info_event_structure():
    """_build_info_event should describe the configured model and language."""
    handler = MoonshineAsrHandler(
        reader=object(),
        writer=object(),
        model_name="moonshine/tiny",
        language="en-US",
    )

    event = handler._build_info_event()

    assert event.type == "info"
    assert "asr" in event.data
    assert isinstance(event.data["asr"], list)
    assert len(event.data["asr"]) == 1

    asr_program = event.data["asr"][0]
    assert asr_program["name"] == "moonshine-onnx"
    assert asr_program["installed"] is True

    models = asr_program["models"]
    assert isinstance(models, list)
    assert len(models) == 1

    model = models[0]
    assert model["name"] == "moonshine/tiny"
    assert model["installed"] is True
    assert model["languages"] == ["en-US"]
