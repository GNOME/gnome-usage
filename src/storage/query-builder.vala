
public class Usage.StorageQueryBuilder {
    public string enumerate_children (string uri, bool recursive = false) {
        string filter;
        if (recursive) {
            filter = @"tracker:uri-is-descendant ('$uri', ?uri)";  
        } else {
            filter = @"tracker:uri-is-parent ('$uri', ?uri)";
        }

        return @"SELECT ?uri rdf:type(?u) { ?u nie:url ?uri . FILTER($filter) }";
    }
}
