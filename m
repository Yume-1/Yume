-- Avatars policies (public bucket)
CREATE POLICY "Avatar images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "Authenticated users can upload avatars" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'avatars' 
        AND auth.role() = 'authenticated'
    );

CREATE POLICY "Users can update own avatars" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'avatars' 
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Post images policies (public bucket)
CREATE POLICY "Post images are publicly accessible" ON storage.objects
    FOR SELECT USING (bucket_id = 'post-images');

CREATE POLICY "Authenticated users can upload post images" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'post-images' 
        AND auth.role() = 'authenticated'
    );

-- Voice messages policies (private bucket)
CREATE POLICY "Users can access voice messages they sent or received" ON storage.objects
    FOR SELECT USING (
        bucket_id = 'voice-messages' 
        AND (
            auth.uid()::text = (storage.foldername(name))[1]
            OR EXISTS (
                SELECT 1 FROM messages 
                WHERE (voice_url LIKE '%' || name || '%')
                AND (sender_id = auth.uid() OR receiver_id = auth.uid())
            )
        )
    );

CREATE POLICY "Authenticated users can upload voice messages" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'voice-messages' 
        AND auth.role() = 'authenticated'
    );