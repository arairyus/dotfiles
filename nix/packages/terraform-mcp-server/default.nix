{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "terraform-mcp-server";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "hashicorp";
    repo = "terraform-mcp-server";
    rev = "v${version}";
    hash = "sha256-4NUSMNLWn5Pmwq//M0yHn7qw9oUI4Q3MDXeQ8xBLLSI=";
  };

  vendorHash = "sha256-FuAt2epg4wH7oNa0nvQMWZZwOL1YtpSVdEBxkeY2Heg=";

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.2" "go 1.26.1"
  '';

  subPackages = [ "cmd/terraform-mcp-server" ];

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "MCP server for Terraform Registry and HCP Terraform APIs";
    homepage = "https://github.com/hashicorp/terraform-mcp-server";
    license = lib.licenses.mpl20;
    mainProgram = "terraform-mcp-server";
  };
}
