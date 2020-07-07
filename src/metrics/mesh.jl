export laplacian_loss, edge_loss

function laplacian_loss(m::TriMesh)
    # TODO: There will be some changes when migrating to batched format
    L = Zygote.@ignore get_laplacian_packed(m)
    verts = get_verts_packed(m)
    L = L * verts
    L = _norm(L; dims = 2)
    return mean(L)
end

function _edge_loss2(m::TriMesh, target_length::Number=0.0f0)
    #TODO: This is different approach to calculate edge_loss, remove one approach
    verts = get_verts_packed(m)
    faces = get_faces_packed(m)

    p1 = verts[faces[:,1],:]
    p2 = verts[faces[:,2],:]
    p3 = verts[faces[:,3],:]

    e1 = p2-p1
    e2 = p3-p2
    e3 = p1-p2

    el1 = (_norm(e1; dims=2) .- Float32(target_length)) .^ 2
    el2 = (_norm(e1; dims=2) .- Float32(target_length)) .^ 2
    el3 = (_norm(e1; dims=2) .- Float32(target_length)) .^ 2

    # assuming homogenous mesh, each edge is shared between faces
    loss = (mean(el1) + mean(el2) + mean(el3)) / 6
    return loss
end

function edge_loss(m::TriMesh, target_length::Number=0.0)
    #TODO: will change changing to batched format
    verts = get_verts_packed(m)
    edges = Zygote.@ignore get_edges_packed(m)
    v1 = verts[edges[:,1],:]
    v2 = verts[edges[:,2],:]
    el =  (_norm(v1-v2; dims=2) .- Float32(target_length)) .^ 2
    loss = mean(el)
    return loss
end

function chamfer_distance(m1::TriMesh, m2::TriMesh, num_samples::Int = 5000; w1::Number=1.0, w2::Number=1.0)
    A = sample_points(m1, num_samples)
    B = sample_points(m2, num_samples)
    # return _chamfer_distance(Float32.(A), Float32.(B), Float32(w1), Float32(w2))
    return _chamfer_distance(A, B, Float32(w1), Float32(w2))
end

function normal_consistency_loss(m::TriMesh)
#     edges = get_edges(m)
    error("Not implemented")
end

function cloud_surface_distance(m::TriMesh)
    error("Not implemented")
end
