import * as childProcess from "child_process";
import fs from "fs";

const repos = [
  {owner: "abapGit", repo: "abapGit", folder: "src", license: "/LICENSE"},
  {owner: "larshp", repo: "abapOpenChecks", folder: "src", license: "/LICENSE"},
  {owner: "larshp", repo: "abapPGP", folder: "src", license: "/LICENSE"},
  {owner: "stockbal", repo: "abap-db-browser", folder: "src", license: "/LICENSE"},
  {owner: "SAP", repo: "code-pal-for-abap", folder: "src", license: "/LICENSE"},
  {owner: "pixelbaker", repo: "ABAP-RayTracer", folder: "src", license: "/LICENSE"},
  {owner: "rayatus", repo: "sapbugtracker", folder: "zbugtracker_core", license: "/LICENSE"},
  {owner: "watson-developer-cloud", repo: "abap-sdk-nwas", folder: "src", license: "/LICENSE"},
  {owner: "nomssi", repo: "abap_scheme", folder: "src", license: "/LICENSE"},
  {owner: "bizhuka", repo: "xtt", folder: "src", license: "/LICENSE"},
  {owner: "sapmentors", repo: "abap2xlsx", folder: "src", license: "/LICENSE"},
  {owner: "microsoft", repo: "ABAP-SDK-for-Azure", folder: "src", license: "/LICENSE"},
];

for (const r of repos) {
  childProcess.execSync("rm -rf " + r.repo, {stdio: "inherit"});
  childProcess.execSync("git clone https://github.com/" + r.owner + "/" + r.repo + ".git", {stdio: "inherit"});
  childProcess.execSync("rm -rf src/" + r.repo + "", {stdio: "inherit"});
  fs.mkdirSync("src/" + r.repo + "");
  childProcess.execSync("cp -r " + r.repo + "/" + r.folder + "/* src/" + r.repo + "", {stdio: "inherit"});
  childProcess.execSync("cp " + r.repo + r.license + " src/" + r.repo + "", {stdio: "inherit"});
  childProcess.execSync("rm -rf " + r.repo + "", {stdio: "inherit"});
}

childProcess.execSync("abaplint -p -f total || true", {stdio: "inherit", });

childProcess.execSync("find -name '*.abap' | xargs cat | wc -l", {stdio: "inherit"});