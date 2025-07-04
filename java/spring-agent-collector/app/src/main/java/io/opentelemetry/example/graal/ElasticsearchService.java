package io.opentelemetry.example.graal;

import co.elastic.clients.elasticsearch.ElasticsearchClient;
import co.elastic.clients.elasticsearch.core.IndexRequest;
import co.elastic.clients.elasticsearch.core.SearchRequest;
import co.elastic.clients.elasticsearch.core.SearchResponse;
import co.elastic.clients.elasticsearch.core.search.Hit;
import co.elastic.clients.json.jackson.JacksonJsonpMapper;
import co.elastic.clients.transport.ElasticsearchTransport;
import co.elastic.clients.transport.rest_client.RestClientTransport;
import org.apache.http.HttpHost;
import org.elasticsearch.client.RestClient;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class ElasticsearchService {

    private ElasticsearchClient client;

    @PostConstruct
    public void init() {
        RestClient restClient = RestClient.builder(
                new HttpHost("elasticsearch", 9200)
        ).build();

        ElasticsearchTransport transport = new RestClientTransport(
                restClient,
                new JacksonJsonpMapper()
        );

        this.client = new ElasticsearchClient(transport);

        // Initialize with some sample data
        initializeSampleData();
    }

    private void initializeSampleData() {
        try {
            // Create sample documents
            Map<String, Object> doc1 = new HashMap<>();
            doc1.put("name", "John Doe");
            doc1.put("age", 30);
            doc1.put("city", "New York");

            Map<String, Object> doc2 = new HashMap<>();
            doc2.put("name", "Jane Smith");
            doc2.put("age", 25);
            doc2.put("city", "San Francisco");

            // Index the documents
            client.index(IndexRequest.of(i -> i
                    .index("users")
                    .id("1")
                    .document(doc1)
            ));

            client.index(IndexRequest.of(i -> i
                    .index("users")
                    .id("2")
                    .document(doc2)
            ));

        } catch (IOException e) {
            System.err.println("Failed to initialize sample data: " + e.getMessage());
        }
    }

    public List<Map<String, Object>> searchUsers(String query) throws IOException {
        SearchRequest searchRequest = SearchRequest.of(s -> s
                .index("users")
                .query(q -> q.matchAll(m -> m))
        );

        SearchResponse<Map> response = client.search(searchRequest, Map.class);

        List<Map<String, Object>> results = new ArrayList<>();
        for (Hit<Map> hit : response.hits().hits()) {
            Map<String, Object> source = hit.source();
            if (source != null) {
                results.add(source);
            }
        }

        return results;
    }

    public List<Map<String, Object>> searchUsersByName(String name) throws IOException {
        SearchRequest searchRequest = SearchRequest.of(s -> s
                .index("users")
                .query(q -> q.match(m -> m.field("name").query(name)))
        );

        SearchResponse<Map> response = client.search(searchRequest, Map.class);

        List<Map<String, Object>> results = new ArrayList<>();
        for (Hit<Map> hit : response.hits().hits()) {
            Map<String, Object> source = hit.source();
            if (source != null) {
                results.add(source);
            }
        }

        return results;
    }
}
