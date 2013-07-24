# -*- coding: UTF-8 -*-
from rdfalchemy.sparql import SPARQLGraph


def find_related_persons(person_uri):
    graph = SPARQLGraph('http://dbpedia.org/sparql')
    query = '''
        PREFIX dcterms: <http://purl.org/dc/terms/>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        SELECT DISTINCT ?other_person ?o WHERE {
            <%s> dcterms:subject ?o .
            ?other_person a <http://dbpedia.org/ontology/Person> ;
                dcterms:subject ?o .
        } LIMIT 1000
    '''
    # query = '''
    #     PREFIX dcterms: <http://purl.org/dc/terms/>
    #     PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
    #     SELECT DISTINCT ?other_person ?p WHERE {
    #         <%s> ?p ?other_person.
    #         ?other_person a <http://dbpedia.org/ontology/Person> .
    #     }
    # '''
    query = query % person_uri
    related_concepts = []
    for r in graph.query(query, resultMethod='json'):
        related_concepts.append((str(r[0]), str(r[1])))
    return related_concepts


def find_related_persons_set(person_set):
    related_concepts = set()
    for person in person_set:
        related_concepts.add(person)
    return related_concepts


def find_social_relationship_path(person1, person2):
    person1_related = set(find_related_persons(person1))
    person2_related = set(find_related_persons(person2))
    loop = 1
    while len(person1_related.intersection(person2_related)) == 0 and loop < 1000:
        person1_related.union(find_related_persons_set(person1_related))
        person2_related.union(find_related_persons_set(person2_related))
        print loop
        loop += 1
    return person1_related.intersection(person2_related)


def find_relationships(person1, person2):
    graph = SPARQLGraph('http://dbpedia.org/sparql')
    query = '''
        PREFIX dcterms: <http://purl.org/dc/terms/>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        SELECT DISTINCT ?p ?o WHERE {
            <%s> ?p ?o .
            <%s> ?p ?o .
            FILTER (?p != <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> && ?p != <http://dbpedia.org/property/wikiPageUsesTemplate> && ?p != <http://dbpedia.org/property/wordnet_type> )
        }
    '''
    query = query % (person1, person2)
    relationships = []
    for r in graph.query(query, resultMethod='json'):
        relationships.append((str(r[0]), str(r[1])))
    return relationships


def find_persons_share_prop(person, preidicate, value):
    graph = SPARQLGraph('http://dbpedia.org/sparql')
    query = '''
        PREFIX dcterms: <http://purl.org/dc/terms/>
        PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
        PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
        SELECT DISTINCT ?other_person WHERE {
            <%s> <%s> %s .
            ?other_person a <http://dbpedia.org/ontology/Person> ;
                <%s> %s .
        }
    '''
    query = query % (person, preidicate, value, preidicate, value)
    relationships = []
    for r in graph.query(query, resultMethod='json'):
        relationships.append(str(r[0]))
    return relationships


if __name__ == '__main__':
    # print find_related_persons('http://dbpedia.org/resource/David_Cameron')
    # print find_social_relationship_path('http://dbpedia.org/resource/David_Cameron', 'http://dbpedia.org/resource/Danny_Alexander')
    # print find_relationships('http://dbpedia.org/resource/David_Cameron', 'http://dbpedia.org/resource/Nick_Clegg')
    print find_persons_share_prop('http://dbpedia.org/resource/David_Cameron',
        'http://dbpedia.org/ontology/birthDate', '"1966-10-09"^^xsd:date')

