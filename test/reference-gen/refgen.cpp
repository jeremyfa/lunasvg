/*
 * Reference generator for the lunasvg Haxe port.
 *
 * Reads a case list (see test/cases-*.txt): one case per line,
 *
 *     <name> <svg-path> <width> <height> <mode>
 *
 * where <width> and <height> are passed to Document::renderToBitmap() (0 means
 * intrinsic size) and <mode> is "plain" or "white" (the root element gets
 * color="#ffffff", so that currentColor is white, as used for Lucide icons).
 * Paths are relative to the list file directory, except paths starting with
 * "lucide:", relative to the LUCIDE_DIR environment variable.
 *
 * For every case, a line "<name> <width> <height> <hash>" (or "<name> null")
 * is written to <outdir>/<listname>.hashes, where <hash> is the FNV-1a 32-bit
 * hash of the raw surface memory (premultiplied ARGB, one little-endian
 * uint32 per pixel, stride = width * 4). With --raw, the surface memory is
 * also written to <outdir>/raw/<name>.raw ('/' in names replaced by '__').
 *
 * Usage: refgen <list> <outdir> [--raw]
 */

#include <lunasvg.h>

#include <cstdio>
#include <cstdlib>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>

using namespace lunasvg;

static uint32_t fnv1a(const uint8_t* data, size_t length)
{
    uint32_t hash = 0x811c9dc5u;
    for(size_t i = 0; i < length; i++) {
        hash ^= data[i];
        hash *= 0x01000193u;
    }

    return hash;
}

static std::string flatName(std::string name)
{
    std::string out;
    for(char c : name) {
        if(c == '/')
            out += "__";
        else
            out += c;
    }

    return out;
}

int main(int argc, char** argv)
{
    if(argc < 3) {
        std::fprintf(stderr, "usage: refgen <list> <outdir> [--raw]\n");
        return 1;
    }

    std::string listPath(argv[1]);
    std::string outDir(argv[2]);
    bool writeRaw = argc > 3 && std::strcmp(argv[3], "--raw") == 0;

    std::string baseDir = ".";
    auto slash = listPath.find_last_of('/');
    if(slash != std::string::npos)
        baseDir = listPath.substr(0, slash);
    std::string listName = slash == std::string::npos ? listPath : listPath.substr(slash + 1);
    auto dot = listName.find_last_of('.');
    if(dot != std::string::npos)
        listName = listName.substr(0, dot);

    std::ifstream list(listPath);
    if(!list.is_open()) {
        std::fprintf(stderr, "cannot open %s\n", listPath.c_str());
        return 1;
    }

    std::ofstream hashes(outDir + "/" + listName + ".hashes");
    std::string line;
    int count = 0;
    while(std::getline(list, line)) {
        if(line.empty() || line[0] == '#')
            continue;
        std::istringstream ss(line);
        std::string name, path, mode;
        int width = 0, height = 0;
        ss >> name >> path >> width >> height >> mode;
        std::string fullPath = baseDir + "/" + path;
        if(path.compare(0, 7, "lucide:") == 0) {
            const char* lucideDir = std::getenv("LUCIDE_DIR");
            if(lucideDir == nullptr) {
                std::fprintf(stderr, "LUCIDE_DIR is not set\n");
                return 1;
            }

            fullPath = std::string(lucideDir) + "/" + path.substr(7);
        }

        auto document = Document::loadFromFile(fullPath);
        if(document == nullptr) {
            hashes << name << " null\n";
            continue;
        }

        if(mode == "white")
            document->documentElement().setAttribute("color", "#ffffff");
        auto bitmap = document->renderToBitmap(width, height);
        if(bitmap.isNull()) {
            hashes << name << " null\n";
            continue;
        }

        size_t size = size_t(bitmap.stride()) * bitmap.height();
        auto hash = fnv1a(bitmap.data(), size);
        char hex[16];
        std::snprintf(hex, sizeof(hex), "%08x", hash);
        hashes << name << " " << bitmap.width() << " " << bitmap.height() << " " << hex << "\n";
        if(writeRaw) {
            std::ofstream raw(outDir + "/raw/" + flatName(name) + ".raw", std::ios::binary);
            raw.write(reinterpret_cast<const char*>(bitmap.data()), size);
        }

        count++;
    }

    std::printf("%d cases rendered, hashes in %s/%s.hashes\n", count, outDir.c_str(), listName.c_str());
    return 0;
}
