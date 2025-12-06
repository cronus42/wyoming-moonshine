import sys

from wyoming_moonshine.__main__ import _parse_args, _parse_moonshine_options, PROFILES


def test_parse_args_defaults(monkeypatch):
    """Default arguments should match documented CLI examples."""
    monkeypatch.setattr(sys, "argv", ["wyoming-moonshine"])

    args = _parse_args()

    assert args.uri == "tcp://0.0.0.0:10300"
    assert args.model == "moonshine/tiny"
    assert args.language == "en"
    assert args.log_level.upper() == "INFO"


def test_parse_args_overrides(monkeypatch):
    """Command-line flags should override defaults."""
    monkeypatch.setattr(
        sys,
        "argv",
        [
            "wyoming-moonshine",
            "--uri",
            "tcp://127.0.0.1:12345",
            "--model",
            "moonshine/base",
            "--language",
            "en-US",
            "--log-level",
            "DEBUG",
        ],
    )

    args = _parse_args()

    assert args.uri == "tcp://127.0.0.1:12345"
    assert args.model == "moonshine/base"
    assert args.language == "en-US"
    assert args.log_level.upper() == "DEBUG"


def test_parse_moonshine_options_coercion():
    opts = _parse_moonshine_options([
        "int_val=1",
        "float_val=2.5",
        "bool_true=true",
        "bool_false=False",
        "string_val=foo",
    ])

    assert opts["int_val"] == 1
    assert isinstance(opts["int_val"], int)
    assert opts["float_val"] == 2.5
    assert isinstance(opts["float_val"], float)
    assert opts["bool_true"] is True
    assert opts["bool_false"] is False
    assert opts["string_val"] == "foo"


def test_profiles_defined_fast_en():
    profile = PROFILES["fast-en"]
    assert profile["model"] == "moonshine/tiny"
    assert profile["language"] == "en"
    assert profile["max_seconds"] > 0
