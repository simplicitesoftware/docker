import java.nio.file.spi.FileSystemProvider;

public class FileSystemCheck {
    public static void main(String[] args) {
        for(FileSystemProvider provider : FileSystemProvider.installedProviders())
            System.out.println(provider.getScheme());
    }
}
